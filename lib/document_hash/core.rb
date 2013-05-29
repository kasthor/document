module DocumentHash
  class Core < Hash
    def self.[] *attr
      super(*attr).tap do|new|
        new.keys.each do |k|
          if new[k].is_a?(Hash) && ! new[k].is_a?(self.class)
            new[k] = new.class[new.delete(k)] 
          else
            new[k] = new.delete(k)
          end
        end
        #symbolize_keys new
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

      val = execute_before_change_callback key,val
      super key, val
      changed_key key, val
    end

    def reset!
      changed_attributes.clear
    
      values.select{|v| v.is_a? self.class }.each{ |v| v.reset! }
    end

    def merge other
      dup.merge! other
    end

    def merge! other
      self.class.symbolize_keys other
      other = Hash[ other.collect{ |k, v| [ k, execute_before_change_callback(k,v) ] } ]
      super other
      other.each { |k, v| changed_key k,v }
    end

    private 

    attr_accessor :parent, :parent_key

    def changed_key key, value
      path = Array(key)

      @after_change.call path, value if @after_change
      changed_attributes << path.first
      parent.__send__ :changed_key, path.unshift(parent_key), value if parent
    end

    def execute_before_change_callback key, value
      path = Array(key)

      value = @before_change.call path, value if @before_change
      value = parent.__send__ :execute_before_change_callback, path.unshift(parent_key), value if parent
      value
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
