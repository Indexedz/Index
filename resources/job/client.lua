local player = import 'player';
local data   = {
    player = data 'player'
}

local Job = player.useState(data.player.default.job, "job")

player.on("loaded", function()
    local job, state = player.get("job");
    
    Job:setDefault(job)
    state:link('data.job', "@player:job")
end)

RegisterNetEvent("Index.player.job:changed", function(jobName, jobGrade) 
    Job:set({
        job     = jobName,
        grade   = jobGrade
    })
end)