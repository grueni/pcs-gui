def getFenceAgents(fence_agent)
  fence_agent_list = {}
  if fence_agent == nil
    return fence_agent_list
  end

  agents = Dir.glob('/usr/sbin/fence_' + '*')
  agents.each { |a|
    fa = FenceAgent.new
    fa.name =  a.sub(/.*\//,"")

    if a.sub(/.*\//,"") == fence_agent.sub(/.*:/,"")
      required_options, optional_options = getFenceAgentMetadata(fa.name)
      fa.required_options = required_options
      fa.optional_options = optional_options
    end
    fence_agent_list[fa.name] = fa
  }
  fence_agent_list
end

def getFenceAgentMetadata(fenceagentname)
  metadata = `stonith_admin --metadata -a #{fenceagentname}`
  doc = REXML::Document.new(metadata)
  options_required = {}
  options_optional = {}
  doc.elements.each('resource-agent/parameters/parameter') { |param|
    next if param.attributes["name"] == "action"
    if param.attributes["required"] == "1"
      options_required[param.attributes["name"]] = ""
    else
      options_optional[param.attributes["name"]] = ""
    end
  }
  [options_required, options_optional]
end

class FenceAgent
  attr_accessor :name, :resource_class, :required_options, :optional_options
  def initialize(name=nil, required_options={}, optional_options={}, resource_class=nil)
    @name = name
    @required_options = {}
    @optional_options = {}
    @required_options = required_options
    @optional_options = optional_options
    @resource_class = nil
  end

  def type
    name
  end
end