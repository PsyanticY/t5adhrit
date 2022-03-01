Make a cron job in k8s execute now (manually trigger it)
        
        kubectl create job --from=cronjob/cronjobname cronjob-jobname

Forward traffic to a certain pod or service from local machine

        kubectl port-forward service/web  8080:80
        curl localhost:8080
