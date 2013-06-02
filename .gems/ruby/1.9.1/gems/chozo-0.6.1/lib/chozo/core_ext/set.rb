require 'set'

class Set
  # Serialize a Set as it's close cousin - the array
  def to_json(*args)
    self.to_a.to_json(*args)
  end
  alias_method :as_json, :to_json
end
