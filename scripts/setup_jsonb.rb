initializer 'update_jsonb.rb', <<-RUBY
ActiveRecord::Base.before_save do
  self.class.column_names.each do |c|
    send("\#{c}_will_change!") if column_for_attribute(c).type == :jsonb
  end
end
RUBY