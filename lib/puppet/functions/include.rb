# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----
# Include the specified classes
# ---- original file header ----
#
# @summary
#   Evaluate one or more classes.
#
Puppet::Functions.create_function(:'include') do
  # @param vals
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :vals
  end


  def default_impl(*vals)
    
        vals = [vals] unless vals.is_a?(Array)

        # The 'false' disables lazy evaluation.
        klasses = compiler.evaluate_classes(vals, self, false)

        missing = vals.find_all do |klass|
            ! klasses.include?(klass)
        end

        unless missing.empty?
            # Throw an error if we didn't evaluate all of the classes.
            str = "Could not find class"
            if missing.length > 1
                str += "es"
            end

            str += " " + missing.join(", ")

            if n = namespaces and ! n.empty? and n != [""]
                str += " in namespaces %s" % @namespaces.join(", ")
            end
            self.fail Puppet::ParseError, str
        end

  end
end