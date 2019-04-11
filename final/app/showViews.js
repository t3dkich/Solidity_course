const showViewService = (() => {
    async function showAddJob() {
        let html = await $.get('./templates/addJob.hbs')

        $('#jobs').hide()
        $('#myJobs').hide()
        $('#job').show().empty().append(html)

        $('#submitNewJob').on('click', () => {
            let data = {
                title: $('#jobTitle').val(),
                reward: $('#jobReward').val(),
                description: $('#addJobDescription').val()
            }
            return helperService.addJob(data)
        })
    }

    async function showHome() {
        let html = await $.get('./templates/singleJob.hbs')
        let template = Handlebars.compile(html)
        let hash = await contract.getJobsHash();
        let usersJobs = JSON.parse(await node.cat(hash))
        allJobs = []   
        for(key in usersJobs) {
            let [address, userHash] = [key, usersJobs[key]] 
            let ipfsUser = JSON.parse(await node.cat(userHash))
            for(job of ipfsUser.jobs) {
                job.userHash = userHash
                allJobs.push(job)
            }    
        }

        let ctx = {jobs: allJobs}
        $('#myJobs').hide()
        $('#job').hide()
        $('#jobs').show().empty().append(template(ctx))
        
    }

    function showAddSolution(event) {
        let targetBtn = $(event.target)
        targetBtn.parent().parent().find('textarea').parent().toggle()
    }

    async function showMyJobs() {
        let html = await $.get('./templates/mySingleJob.hbs')
        let template = Handlebars.compile(html)

        const userAddress = provider._web3Provider.selectedAddress
        let {userJobs, userHash} = await helperService.getUserIpfs(userAddress)
        let allJobs = []
        for(job of userJobs.jobs) {
            job.userHash = userHash
            allJobs.push(job)
        }

        $('#job').hide()
        $('#jobs').hide()
        let ctx = {jobs: allJobs}
        $('#myJobs').show().empty().append(template(ctx))
    }

    return {
        showAddJob,
        showHome,
        showAddSolution,
        showMyJobs
    }
})()