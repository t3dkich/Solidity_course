const helperService = (() => {
    async function addUser(userAddress, jobData) {
        let user = JSON.stringify({
            address: userAddress,
            jobCount: 1,
            jobs: []
        })
        let newUserHash = await node.add(node.types.Buffer.from(user))
        let userObj = JSON.parse(await node.cat(newUserHash[0].hash))
        userObj.jobs.push(jobData)

        let userHash = await node.add(node.types.Buffer.from(JSON.stringify(userObj)))

        let jobsHash = await contract.getJobsHash()
        let allUsers = JSON.parse(await node.cat(jobsHash))
        allUsers[userAddress] = userHash[0].hash
        let finalJobsHash = await node.add(node.types.Buffer.from(JSON.stringify(allUsers)))

        let msg = {
            value: new ethers.utils.parseEther(jobData.reward.toString())
        }
        await contract.userAndJobsHashes(0, userHash[0].hash, finalJobsHash[0].hash, msg)
        console.log(JSON.parse(await node.cat(userHash[0].hash)))
        // ne zadalje
        // let trye = await node.cat(finalJobsHash[0].hash)
        // console.log(JSON.parse(trye))
    }

    async function addJob(dataJob) {

        dataJob.id = mwUnique.getUniqueID()
        const userAddress = provider._web3Provider.selectedAddress
        let {userJobs, userHash} = await getUserIpfs(userAddress)

        if (!userJobs) return addUser(userAddress, dataJob)
        if (userJobs.jobCount > 4) return console.log('saobshteniq za ogranichenie na jobovete')

        userJobs.jobs.push(dataJob)
        userJobs.jobCount++;
        let userHashNew = await node.add(node.types.Buffer.from(JSON.stringify(userJobs)))

        helperFunc(userHashNew[0].hash, userAddress, dataJob.reward)
        let userr = await contract.getUser(userAddress)
    
    }

    async function helperFunc(userHash, userAddress, reward) {
        let jobsHash = await contract.getJobsHash()
        let allUsers = await node.cat(jobsHash)
        allUsers = JSON.parse(allUsers)
        allUsers[userAddress] = userHash
        let finalJobsHash = await node.add(node.types.Buffer.from(JSON.stringify(allUsers)))
        let msg = {
            value: new ethers.utils.parseEther(reward.toString())
        }

        await contract.userAndJobsHashes(1, userHash, finalJobsHash[0].hash, msg)
        

        // ne zadalje
        // let trye = await node.cat(finalJobsHash[0].hash)
        // console.log(JSON.parse(trye))
        // console.log(JSON.parse(await node.cat(userHash)))

    }

    async function addSolution(userHash, jobId, jobSolution) {
        userIpfs = JSON.parse(await node.cat(userHash))
        for (job of userIpfs.jobs) {
            if (job.id === jobId) {
                if (!job.solutions) job['solutions'] = []
                job.solutions.push({
                    solution: jobSolution,
                    userAddress: provider._web3Provider.selectedAddress
                })
                break
            }
        }
        
        let newUserHash = await node.add(node.types.Buffer.from(JSON.stringify(userIpfs)))

        let jobsHash = await contract.getJobsHash()
        let userVsJob = JSON.parse(await node.cat(jobsHash))
        userVsJob[userIpfs.address] = newUserHash[0].hash
        let newJobsHash = await node.add(node.types.Buffer.from(JSON.stringify(userVsJob)))
        await contract.updateForSolutions(newUserHash[0].hash, newJobsHash[0].hash, userIpfs.address)

        // probi
        // let newnewUser = JSON.parse(await node.cat(newUserHash[0].hash))
        // let [funds, hash] = await contract.getUser(newnewUser.address)
        // let again = JSON.parse(await node.cat(hash))
        // console.log(newnewUser)
        // console.log(hash)
        // console.log(again)
        
    }

    function getSolutionData(event) {
        let targetBtn = $(event.target);
        let jobSolution = targetBtn.parent().find('textarea').val()
        let inputs = targetBtn.parent().parent().find('input')
        let hashAndId = []
        for (value of inputs) {
            hashAndId.push($(value).val())
        }
        return addSolution(hashAndId[0], hashAndId[1], jobSolution)
    }

    async function payForSolution(event) {
        let jobInputs = $(event.target).parent().parent().find('input')
        let solutionInputs = $(event.target).parent().find('input')
        let [userHash, jobId, jobReward] = [$(jobInputs[0]).val(), $(jobInputs[1]).val(), $(jobInputs[2]).val()]
        let [userSolutionAddress, jobIndex] = [$(solutionInputs[0]).val(), $(solutionInputs[1]).val()]

        let userIpfs = JSON.parse(await node.cat(userHash))
        console.log(userIpfs)
        for(job of userIpfs.jobs) {
            if (job.id == jobId) {
                job.isFinished = true
                break
            }
        }
        let updateUserHash = await node.add(node.types.Buffer.from(JSON.stringify(userIpfs)))
        let allJobsHash = await contract.getJobsHash()
        let allJobs = JSON.parse(await node.cat(allJobsHash))
        allJobs[userIpfs.address] = updateUserHash[0].hash
        let updateAllJobsHash = await node.add(node.types.Buffer.from(JSON.stringify(allJobs)))

        await contract.updateHasheshAndPaySolution(
            updateUserHash[0].hash,
            updateAllJobsHash[0].hash,
            userSolutionAddress,
            ethers.utils.parseEther(jobReward)
        )
        
    }

    async function getUserIpfs(userAddress) {
        let isUser = await contract.isUser(userAddress)
        if (!isUser) return false

        let [funds, userHash] = await contract.getUser(userAddress)
        let userJobs = JSON.parse(await node.cat(userHash))

        return {userJobs, userHash}
    }

    function UniqueIdGenerator() {
        window.mwUnique = {
            prevTimeId: 0,
            prevUniqueId: 0,
            getUniqueID: function () {
                try {
                    var d = new Date();
                    var newUniqueId = d.getTime();
                    if (newUniqueId == mwUnique.prevTimeId)
                        mwUnique.prevUniqueId = mwUnique.prevUniqueId + 1;
                    else {
                        mwUnique.prevTimeId = newUniqueId;
                        mwUnique.prevUniqueId = 0;
                    }
                    newUniqueId = newUniqueId + '' + mwUnique.prevUniqueId;
                    return newUniqueId;
                }
                catch (e) {
                    mwTool.logError('mwUnique.getUniqueID error:' + e.message + '.');
                }
            }
        }

    }

    return {
        addJob,
        UniqueIdGenerator,
        getSolutionData,
        getUserIpfs,
        payForSolution
    }
})()