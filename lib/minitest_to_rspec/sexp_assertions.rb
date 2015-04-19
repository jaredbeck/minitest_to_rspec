module MinitestToRspec

  # Useful runtime assertions regarding S-expressions.
  module SexpAssertions
    def assert_sexp_type_array(type, obj)
      unless obj.is_a?(Array) && obj.all? { |x| sexp_type?(type, x) }
        raise TypeError, "Expected array of #{type} sexp, got #{obj.inspect}"
      end
    end

    def assert_sexp_type(type, exp)
      unless sexp_type?(type, exp)
        raise TypeError, "Expected #{type} s-expression, got #{exp.inspect}"
      end
    end

    def sexp_type?(type, exp)
      exp.is_a?(Sexp) && exp.sexp_type == type.to_sym
    end
  end
end
