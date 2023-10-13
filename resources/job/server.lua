local player   = import 'player'
local job      = import 'job'
local array    = import 'array'
local hook     = import 'hook'
local server   = import 'server'
local callback = import 'callback'
local data     = {
    job    = data 'job',
    server = data 'server'
}

local function setJob(playerId, jobName, jobGrade)
    local xPlayer, xCharacter = player.find(playerId)
    local xJob    = job.find(jobName)

    if not xPlayer then return end
    if not xCharacter then return end
    if not xJob then return end
    if not xJob.grade(jobGrade) then return end

    local oldJob = xCharacter.get("job");
    xCharacter:set("job", {
        job     = xJob.name,
        grade   = jobGrade
    }, false, function(value)
        server.trigger("@player:job", "changed", playerId, value, oldJob)
        xPlayer:trigger("Index.player.job:changed", value, oldJob)
    end)
end

player.export(function(playerId, jobName, jobGrade)
    if not jobName then return false end
    if not jobGrade then return false end

    setJob(playerId, jobName, jobGrade)
end, "SetJob")

lib.addCommand('setJob', {
    help = 'set player job',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
        },
        {
            name = 'jobName',
            type = 'string',
            help = 'jon Name',
        },
        {
            name = 'jobGrade',
            type = 'number',
            help = 'Job Grade',
            optional = true,
        }
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    setJob(args.target, args.jobName, args.jobGrade or 0)
end)

hook.useTick(function()
    player.all(function(xPlayer, xCharacter)
        local xJob = xCharacter.get("job")
        local info = job.find(xJob.job)
        local payment = info.grades[xJob.grade]?.payment or 0;

        if (payment > 0)then
            local Account = xCharacter.Account("bank");
            Account:add(payment, "Paycheck")
        end 
    end, true)
end, data.server.paycheck)
