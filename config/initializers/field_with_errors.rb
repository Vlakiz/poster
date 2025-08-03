ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    if html_tag =~ /^<(?:input|textarea)/
        method_name = instance.instance_variable_get("@method_name")
        human_method_name = instance.object.class.human_attribute_name(method_name)
        error_li_elems = %(<li class="list-group-item">#{human_method_name} #{instance.error_message[0]}</li>)
        error_block = %(<div class="invalid-feedback"><ul class="ps-2">#{error_li_elems}</ul></div>)
        %(#{html_tag.gsub('form-control', 'form-control is-invalid')}#{error_block}).html_safe
    else
        %(#{html_tag}).html_safe
    end
end
