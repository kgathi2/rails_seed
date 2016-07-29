create_file 'app/serializers/hash_serializer.rb' do <<-RUBY
class HashSerializer < ::Hashie::Mash
  # Usage =>
  # serialize :data, HashSerializer
  # store_accessor :data, :musoni

  def self.dump(hash)
    hash.to_json
  end

  def self.load(hash)
    json = JSON.parse((hash || {}).to_json, symbolize_names: true) rescue hash
    new(json)
  end
end
RUBY
end