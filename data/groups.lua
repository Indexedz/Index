local jobs   = data 'job'.Jobs;
local groups = {
  {
    name = "normal",
    permissions = {}
  },
  {
    name = "admin",
    include = -1,
    permissions = {
      "command allow"
    }
  }
}

for jobName, jobData in pairs(jobs) do
  for gradeId, gradeData in pairs(jobData.grades) do
    local groupName = ("JOB:%s[%s]"):format(jobName, gradeId);
    local childGroup = ("JOB:%s[%s]"):format(jobName, gradeId - 1);
    table.insert(groups, {
      name = groupName,
      include = gradeId - 1 ~= 0 and childGroup or "normal",
      permissions = gradeData.permissions or {}
    })
  end
end

return groups
