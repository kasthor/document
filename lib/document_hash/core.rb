module DocumentHash

  class Nil
    attr_accessor :parent
    def path
      @path ||= []
    end

    def initialize parent = nil, hash_path = nil
      @parent = parent
      @path = hash_path 
    end

    def nil?
      true
    end

    def == val
      val == false 
    end

    def method_missing method, *args
      if method =~ /^(.*)=/
        parent.__send__ :create_path, (self.path << $1.to_sym), args.pop
      else
        return self.class.new( self.parent, self.path << method)
      end
    end
  end

  class Core < Hash

    def method_missing method, *args
      if method =~ /^(.*)=$/
        self.__send__(:[]=, method[0..-2], args.pop)
      else
        self.__send__(:[], method) || DocumentHash::Nil.new(self, [method])
      end
    end

    def self.[] hash, parent = nil, parent_key = nil
      super(hash).tap do|new|
        new.__send__ :parent=, parent if parent
        new.__send__ :parent_key=, parent_key if parent_key
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
        val = self.class[val, self, key] 
      end

      val = execute_before_change_callback key,val
      super key, val
      changed_key key, val
    end

    def reset!
      changed_attributes.clear
    
      values.select{|v| v.is_a? self.class }.each{ |v| v.reset! }
    end

    def touch!
      self.each do |key, value|
        if value.is_a? self.class
          value.touch!
        else
          changed_key key,value
        end
      end
    end

    def merge other
      dup.merge! other
    end

    def merge! other
      other.each { |k, v| self[k] = v }

      self
    end

    def to_hash
      Hash[
        self.collect do |k,v|
          if v.is_a? DocumentHash::Core
            [ k, v.to_hash ]
          else
            [ k, v ]
          end
        end
      ]
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

    def create_path path, value
      curr = self
      path.each_with_index do |key, index|
        unless index == path.size - 1
          curr[key] = self.class.new
          curr = curr[key]
        else
          curr[key] = value
        end
      end
      curr = value
    end

    def self.symbolize_keys hash
      hash.keys.each do |key|
        hash[(key.to_sym rescue key) || key] = hash.delete(key)
      end
    end

  end
end
