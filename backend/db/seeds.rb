# Create Admin User
admin = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.name = "Admin User"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :admin
end

puts "Admin user created: admin@example.com / password123"

# Create Member Users
member1 = User.find_or_create_by!(email: "member1@example.com") do |user|
  user.name = "Alice Johnson"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :member
end

member2 = User.find_or_create_by!(email: "member2@example.com") do |user|
  user.name = "Bob Smith"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = :member
end

puts "Member users created"

# Create Sample Leads
leads_data = [
  { name: "Sarah Connor", email: "sarah@example.com", phone: "+1-555-0101", company: "TechCorp", message: "Interested in enterprise plan" },
  { name: "John Doe", email: "john@example.com", phone: "+1-555-0102", company: "StartupInc", message: "Looking for demo" },
  { name: "Jane Smith", email: "jane@example.com", phone: "+1-555-0103", company: "BigCo", message: "Need consultation for AI integration" },
  { name: "Mike Wilson", email: "mike@example.com", phone: "+1-555-0104", company: "DataFlow", message: "Follow up on proposal" },
  { name: "Lisa Brown", email: "lisa@example.com", phone: "+1-555-0105", company: "CloudNine", message: "Pricing inquiry" },
  { name: "Tom Hardy", email: "tom@example.com", phone: "+1-555-0106", company: "NetSolutions", message: "Partnership opportunity" },
  { name: "Emma Davis", email: "emma@example.com", phone: "+1-555-0107", company: "GreenEnergy", message: "Interested in sustainability tools" },
  { name: "Alex Turner", email: "alex@example.com", phone: "+1-555-0108", company: "MusicTech", message: "Need custom solution" },
]

statuses = [:new_lead, :contacted, :qualified, :proposal_sent, :won, :lost]

leads_data.each_with_index do |data, index|
  lead = Lead.find_or_create_by!(email: data[:email]) do |l|
    l.name = data[:name]
    l.phone = data[:phone]
    l.company = data[:company]
    l.message = data[:message]
    l.status = statuses[index % statuses.length]
    l.assigned_to = [nil, member1, member2, member1].sample
  end

  # Add a note for some leads
  if index % 2 == 0 && lead.assigned_to.present?
    lead.notes.create!(
      user: lead.assigned_to,
      message: "Initial contact made. Customer seems interested."
    )

    ActivityService.lead_created(lead, lead.assigned_to)
    ActivityService.note_added(lead, lead.assigned_to)
  end
end

puts "Sample leads created with notes and activities"
