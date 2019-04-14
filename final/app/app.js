const App = {
    contract: null,
    provider: null,
    node: null,
    initContract: async function () {
        helperService.UniqueIdGenerator()
        const contractJson = await $.getJSON('../build/contracts/Test.json')
        provider = new ethers.providers.Web3Provider(web3.currentProvider);
        let contractAddress = '0x9c455ac4976756fe99ee1989b3da015801c12ac0'
        contract = new ethers.Contract(contractAddress, contractJson.abi, provider.getSigner());
        node = new window.Ipfs()
        node.once('ready', async () => {

            let initialHash = await contract.getJobsHash()
            if (!initialHash) {
                let jobsHash = await node.add(node.types.Buffer.from(JSON.stringify({})))
                await contract.updateJobsHash(jobsHash[0].hash)
            }
            return showViewService.showHome()
        })
        return App.bindEvents()
    },
    bindEvents: function () {
        $('#addJob').on('click', () => { showViewService.showAddJob() })
        $('#home').on('click', () => { showViewService.showHome() })
        $('#showMyJobs').on('click', () => { showViewService.showMyJobs() })
    }

}

App.initContract()


