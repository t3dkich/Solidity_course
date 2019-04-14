const Test = artifacts.require("Test")

contract("Test", accounts => {
    let test;

    beforeEach(async () => {
        test = await Test.deployed()
    })


    it("should update contract's new jobs hash and call it back to the frontend", async () => {
        await test.updateJobsHash("QmYaXiNQT8qhsw2nN86yhRgSUaA8uit8DXaQFZuEcweuTz")
        let hash = await test.getJobsHash()
        assert.equal(
            hash,
            'QmYaXiNQT8qhsw2nN86yhRgSUaA8uit8DXaQFZuEcweuTz',
            'Incorect Hash'
        )
    })

    it("should ADD NEW user with funds and job hash and check if user exists in contract and retrieve it's data", async () => {
        let msg = {
            from: accounts[0],
            value: 100000
        }

        await test.userAndJobsHashes(0,
            'QmYaXiNQT8qhsw2nN86yhRgSUaA8uit8DXaQFZuEcweuTz',
            'MmYaX3NQTFqhsw2nN86yhRgSUaA8uiv8DXaQFZuEcweiNe',
            msg)

        let isUser = await test.isUser(accounts[0])
        assert.equal(
            isUser,
            true,
            'Incorect boolean for new user'
        )

        let { funds, userHash } = await test.getUser(accounts[0])
        assert.equal(
            funds,
            100000,
            'Incorect value of funds'
        )
        assert.equal(
            userHash,
            'QmYaXiNQT8qhsw2nN86yhRgSUaA8uit8DXaQFZuEcweuTz',
            'Incorect user hash'
        )
    })

    it("should UPDATE user with funds and job hash and retrieve it's UPDATED data", async () => {
        let msg = {
            from: accounts[0],
            value: 100000
        }

        await test.userAndJobsHashes(1,
            'QmYaXiNQT8qhsw2nN86yhRgSUaA8uit8DXaQFZuEcweuTz',
            'MmYaX3NQTFqhsw2nN86yhRgSUaA8uiv8DXaQFZuEcweiNe',
            msg)

        let { funds, userHash } = await test.getUser(accounts[0])
        assert.equal(
            funds,
            200000,
            funds
        )
        assert.equal(
            userHash,
            'QmYaXiNQT8qhsw2nN86yhRgSUaA8uit8DXaQFZuEcweuTz',
            'Incorect user hash'
        )
    })

    it("should get common contract funds by all users together", async () => {
        let contractValue = await test.getContractValue()
        assert.equal(
            contractValue,
            200000,
            'Contract funds do not match the required amount'
        )
    })

    it("should update existing user job hash and all jobs hash", async () => {
        await test.updateForSolutions(
            'IoPaXiNQT8qhsw2sN86yhRgSUaA8uit8DXaQFZvEcwegJc',
            'JkRaX3NQTFqhsw8nK4FyhRg4UaK0uiv8DXaQFZuEcweLvm',
            accounts[0])

        let { funds, userHash } = await test.getUser(accounts[0])
        assert.equal(
            userHash,
            'IoPaXiNQT8qhsw2sN86yhRgSUaA8uit8DXaQFZvEcwegJc',
            'Incorect user hash'
        )

        let hash = await test.getJobsHash()
        assert.equal(
            hash,
            'JkRaX3NQTFqhsw8nK4FyhRg4UaK0uiv8DXaQFZuEcweLvm',
            'Incorect Hash'
        )

    })

    it("should update user hash, all jobs hash and pay solution winner with the reward of the job", async () => {
        await test.updateHasheshAndPaySolution(
            'IoPaXiNQT8qhsw2sN86yhRgSUaA8uit8DXaQFZvEcwegJc',
            'JkRaX3NQTFqhsw8nK4FyhRg4UaK0uiv8DXaQFZuEcweLvm',
            accounts[1],
            100000,
            { from: accounts[0] })

        let jobsHash = await test.getJobsHash()
        assert.equal(
            jobsHash,
            'JkRaX3NQTFqhsw8nK4FyhRg4UaK0uiv8DXaQFZuEcweLvm',
            'Incorect jobs Hash'
        )

        let { funds, userHash } = await test.getUser(accounts[0])
        assert.equal(
            userHash,
            'IoPaXiNQT8qhsw2sN86yhRgSUaA8uit8DXaQFZvEcwegJc',
            'Incorect user hash'
        )
        assert.equal(
            funds,
            100000,
            funds
        )
    })
})