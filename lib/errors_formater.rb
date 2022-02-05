module ErrorsFormater

  def fill_custom_errors(object, field, message)
    object_errors = object.errors
    object_errors << { message: message, field: field, }
  end

  private

  def fill_errors(object)
    details_hash = object.errors.details
    error_types = []
    error_fields = []
    error_messages = slice_full_messages(object.errors.full_messages, details_hash)
    details_hash.each do |key, value|
      error_fields << key.to_s
      error_types << value
    end
    types_and_messages = zip_types_and_messages(error_types, error_messages, details_hash.length)
    merge_messages_and_fields(types_and_messages, error_fields)
  end

  def slice_full_messages(full_messages, details_hash)
    error_messages = []
    details_hash.each do |_, value|
      error_messages << full_messages.slice!(0, value.length)
    end
    error_messages
  end

  def zip_types_and_messages(error_types, error_messages, details_hash_length)
    types_and_messages = []
    (0...details_hash_length).each do |i|
      types_and_messages[i] = error_types[i].zip(error_messages[i])
    end

    types_and_messages
  end

  def merge_messages_and_fields(types_and_messages, error_fields)
    errors = []
    types_and_messages.each_with_index do |type_and_message, index|
      type_and_message.each do |element|
        errors << { 'message' => element[1], 'field' => error_fields[index] }
      end
    end
    errors
  end

end