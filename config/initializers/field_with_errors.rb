ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
    if html_tag =~ /^<input/
        method_name = instance.instance_variable_get("@method_name").humanize
        error_li_elems = instance.error_message.map { |msg| %(<li class="list-group-item">#{method_name} #{msg}</li>) }.join
        error_block = %(<div class="invalid-feedback"><ul class="ps-2">#{error_li_elems}</ul></div>)
        %(#{html_tag.gsub('form-control', 'form-control is-invalid')}#{error_block}).html_safe
    else
        %(#{html_tag}).html_safe
    end
end