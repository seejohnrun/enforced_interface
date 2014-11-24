module EnforcedInterface

  class NotImplementedError < StandardError; end

  class << self
    def [](mod)
      cached_proxy_mod_for(mod)
    end

    private

    def cached_proxy_mod_for(mod)
      @@mods ||= Hash.new { |h, k| h[k] = proxy_mod_for(k) }
      @@mods[mod]
    end

    def proxy_mod_for(mod)
      proxy = Module.new
      proxy.class_variable_set :@@mod, mod
      proxy.class_eval do
        class << self
          def included(base)
            mod = class_variable_get :@@mod
            # For each access level
            [:public, :protected, :private].each do |access|
              base_methods = base.send(:"#{access}_instance_methods")
              mod_methods =  mod.send(:"#{access}_instance_methods")
              # Check each module method
              mod_methods.each do |meth|
                # For existence
                if base_methods.include?(meth)
                  # And for arity
                  unless base.send(:"#{access}_instance_method", meth).arity == mod.send(:"#{access}_instance_method", meth).arity
                    raise NotImplementedError, "#{base} supports #{access} instance method #{meth} with incorrect arity"
                  end
                else
                  raise NotImplementedError, "#{base} does not support #{access} instance method #{meth}"
                end
              end
            end
            # We made it!
            base.send :include, mod
          end
        end
      end
      proxy
    end
  end

end
