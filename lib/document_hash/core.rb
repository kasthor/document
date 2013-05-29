module DocumentHash
  class Core < Hash
    def self.[] *attr
      super(*attr).tap do|new|
        new.each do |k,v|
          new[k] = new.class[v] if v.is_a?(Hash) && ! v.is_a?(self.class)
        end

        symbolize_keys new
      end
    end

    def changed
      changed_attributes.dup.freeze
    end

    def changed? 
      ! changed.empty?
    end

    def [] key
      super key.to_sym
    end

    def []= key, val
      key = key.to_sym

      if val.is_a? Hash
        val = self.class[val] 
        val.__send__ :parent=, self;
        val.__send__ :parent_key=, key;
      end

      super key, val
      changed_key key
    end

    def reset!
      changed_attributes.clear
    
      values.select{|v| v.is_a? self.class }.each{ |v| v.reset! }
    end

    def merge other
      self.class.symbolize_keys other
      super other
    end

    def merge! other
      self.class.symbolize_keys other
      super other
    end

    private 

    attr_accessor :parent, :parent_key

    def changed_key key
      path = Array(key)

      @after_change.call path if @after_change
      changed_attributes << path.first
      parent.__send__ :changed_key, path.unshift(parent_key) if parent
    end

    def changed_attributes 
      @changed ||= ::Set.new
    end

    def self.symbolize_keys hash
      hash.keys.each do |key|
        hash[(key.to_sym rescue key) || key] = hash.delete(key)
      end
    end
  end
end
