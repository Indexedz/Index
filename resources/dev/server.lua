local ensure = function(resourceName)
  StopResource(resourceName)
  StartResource(resourceName)
end

RegisterCommand("dev", function(src, args)
  for _, resourceName in pairs(args) do
    ensure(resourceName)
  end
end, true)