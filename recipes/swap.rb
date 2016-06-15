swap_file node["swap"]["filepath"] do
  size node["swap"]["size"]
  persist true
end
