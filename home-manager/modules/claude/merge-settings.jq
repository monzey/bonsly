def merge($existing; $declared):
  if ($existing | type) == "object" and ($declared | type) == "object" then
    reduce ($declared | keys_unsorted[]) as $key
      ($existing; .[$key] = merge(.[$key]; $declared[$key]))
  elif ($existing | type) == "array" and ($declared | type) == "array" then
    ($existing + $declared | unique)
  else
    $declared
  end;

if all(.[]; type == "object") then
  reduce .[] as $settings ({}; merge(.; $settings))
else
  error("Claude settings must contain JSON objects")
end
