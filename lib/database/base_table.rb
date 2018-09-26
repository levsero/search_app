class BaseTable
  def find_by(value, field)
    results = field.empty? ? search(value) : search_by_field(value, field)
    results.map { |datum| datum.merge(associations_for(datum)) }
  end
  
  private

  def search(search_value)
    data.select do |datum|
      datum.values.any? do |field_value|
        (field_value.is_a?(Array) && field_value.include?(search_value)) || field_value.to_s == search_value
      end
    end
  end

  def search_by_field(search_value, field)
    data.select do |datum|
      if datum[field].is_a? Array
        datum[field].include?(search_value)
      else
        datum[field].to_s == search_value
      end
    end
  end
end
