{
   "webhook" : {
      "filters" : [
         {
            "matchEquals" : "refs/heads/{Branch}",
            "jsonPath" : "$$.ref"
         }
      ],
      "authentication" : "GITHUB_HMAC",
      "targetPipeline" : "${pipeline_name}",
      "targetAction" : "${target_action}",
      "name" : "${webhook_name}",
      "authenticationConfiguration" : {
         "SecretToken" : "${token}"
      }
   }
}
