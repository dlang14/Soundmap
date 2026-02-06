/// <reference path="./.sst/platform/config.d.ts" />

export default $config({
  app(input) {
    return {
      name: "soundmap",
      removal: input?.stage === "production" ? "retain" : "remove",
      protect: ["production"].includes(input?.stage),
      home: "aws",
      providers: {
        aws: {
          region: "us-east-1",
          profile: "dlang-sandbox"
        }
      }
    };
  },

  async run() {
    const dotenv = await import("dotenv")
    const deployableStages = new Set(["dev", "staging", "production"])

    const callerIdentity = await aws.getCallerIdentity()
    const accountId = callerIdentity.accountId
    if (accountId !== "497237776799") {
      console.log("Account ID is not 497237776799, skipping deployment")
      return
    }
    const stage = $app.stage
    const resourceStage = deployableStages.has(stage) ? stage : "dev"
    dotenv.config({
      path: `.env.${resourceStage}`
    })

    console.log("Account ID:", accountId)
    console.log("Stage:", stage)
    console.log("Resource Stage:", resourceStage)
  }
});
