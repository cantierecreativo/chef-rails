swap_file node["rails"]["swap"]["filepath"] do
  size node["rails"]["swap"]["size"]
  persist true
end
