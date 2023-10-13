local data = {
    job = data 'job';
}
local module = {}

function module.find(jobName)
    local self = data.job.Jobs[jobName]
    if not self then return end
    self.name = jobName

    function self.grade(gradeId)
        return self.grades[gradeId]
    end

    return self
end

return module