desc "Add admin role to last user"
task add_admin_role: :environment do
  u = User.last
  puts "Adding admin role to user #{u}"
  u.roles << Role.find_or_create_by(name: 'admin') unless u.admin?
end
