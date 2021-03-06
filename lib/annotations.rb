module JaxrsDoc
  
  class Resource
    include Comparable
    
    attr_reader :name, :description, :params_descriptions, :path, :verbs, :gets, :posts, :puts, :deletes, :consumes
    
    def initialize(file_name, type_annotations, verbs_annotations = {}, type_description = nil, params_descriptions = {})
      @name = file_name
      @description = type_description
      @params_descriptions = params_descriptions
      @path = type_annotations.annotations.find {|a| a.name.eql?"Path"}
      @consumes = type_annotations.annotations.find {|a| a.name.eql?"Consumes"}
      @gets = verbs_annotations[:gets]
      @posts = verbs_annotations[:posts]
      @puts = verbs_annotations[:puts]
      @deletes = verbs_annotations[:deletes]
      @verbs = verbs_annotations
    end
    
    def valid?
      not @path.nil?
    end
    
    def add_param_description(param_description)
      @params_descriptions.update(param_description)
    end
    
    def <=>(another)
      path.value <=> another.path.value
    end
    
    def to_s
      "#{@name} [#{@path.value}]"  
    end
    
    # Support ERB templating of member data.
    def get_binding
      binding
    end
    
  end
  
  class AnnotationsGroup
    
    attr_reader :annotations
    attr_accessor :javadoc
    
    def initialize(annotations = [])
      @annotations = Array.new(annotations)
    end
    
    def method_missing(method_name, *args)
      if(method_name.to_s.include?"params")
        @annotations.select{|a| /\b(Form|FormData|Query)Param\b/ =~ a.name }
      else
        @annotations.find {|a| method_name.to_s.eql?(a.name.downcase) }
      end
    end
    
    def empty?
      @annotations.empty?
    end
    
    def size
      @annotations.size
    end
    
    def to_s
      @annotations.to_s
    end

  end
  
  
  class Annotation
    
    attr_reader :name, :values
    
    def initialize(annotation_text)
      @values = []
      @text = annotation_text.strip
      @name = @text.delete("@").split("(")[0]
      parse_values
    end
    
    def value
      @values[0]
    end
    
    def to_s
      @text
    end
    
    private
    
    def parse_values
      if(matches = /\((.*)\)/.match(@text))
        tokens = matches[1].split(",")
        tokens.each { |v|
          @values << v.gsub(/\"|'/, "").strip
        }
      end
      
      @values.each { |v|
        v.prepend("/") unless v.start_with?("/")
      } if @name == 'Path'
    end
    
  end

end