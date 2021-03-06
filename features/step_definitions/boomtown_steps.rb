Given(/^I'm on the home page$/) do
  @api = Boomtown::Api.new(
      ENV.fetch('BOOMTOWN_USERNAME'),
      ENV.fetch('BOOMTOWN_PASSWORD')
  )
  @web = Boomtown::Web.new
  @web.visit '/'
end

When(/^I search for "([^"]*)"$/) do |q|
  @web.search_for q
end

Then(/^"([^"]*)" appears in the filter list$/) do |term|
  # tags = @web.find '.bt-search-tags'
  # spans = tags.find_elements css: 'span'
  spans = @web.find_all '.bt-search-tags span'
  tag = spans.find { |s| s.text == "Keyword: \"#{term}\"" }

  expect(tag).not_to eq nil
end

And(/^there are at least (\d+) results$/) do |count|
  results = @web.wait_for '.results-paging'
  expect(results.text.to_i).to be > count.to_i
end

And(/^each result mentions (.*)$/) do |phrase|
  links = @web.find_all 'a.at-related-props-card'
  # a .at-related-props-card - things with class inside a tags
  # a.at-related-props-card - a tags with class ...
  links.each do |link|
    href = link.attribute(:href)
    id = href.split('/').last
    result = @api.get_property_details id

    puts id
    expect(result['PublicRemarks'].downcase).to include phrase.downcase
  end
end

And(/^I click "Save Search"$/) do
  button = @web.wait_for('a.js-save-search')
  button.click

  # modal = @web.wait_for('.js-sign-in-modal-switcher')
  # expect(modal.text).to include 'Free Account Activation'
end

And(/^I complete registration$/) do
  step "I fill in email"
  step "I fill in name and phone number"
end

And(/^I fill in email$/) do
  @my_email = Faker::Internet.email

  form = @web.find '.js-register-form'
  i = form.find_element(:name, 'email')
  i.send_keys @my_email

  form.find_element(:css, '.bt-squeeze__button').click
end

And(/^I fill in name and phone number/) do
  @my_name = Faker::Name.name
  @my_phone = '7045551234'

  form2 = @web.wait_for '.js-complete-register-form'
  i = form2.find_element(:name, 'fullname')
  i.send_keys @my_name

  i = form2.find_element(:name, 'phone')
  i.send_keys @my_phone

  complete = @web.find('button.at-submit-btn')
  complete.click

  # Wait for registration to finish
  # @web.wait.until do
  #   el = @web.find '#complete-register-modal'
  #   !el
  # end
  @web.wait_for 'a.js-signout'
end

And(/^I save the search as "([^"]*)"$/) do |name|
  form = @web.wait_for '#save-search-form'
  i = form.find_element(:name, 'searchName')
  i.send_keys name

  form.find_element(:css, '.at-submit-btn').click
end

Then(/^I see "([^"]*)" in my saved searches$/) do |name|
  @web.visit '/notifications'
  first_link = @web.find '#searches a'
  expect(first_link.text).to eq name
end

And(/^I have a user account$/) do
  @web.visit '/account'

  # phone = @web.find '.at-phone-txt'
  # expect(phone.text).to eq @my_phone
end

And(/^my agent is located in Charleston$/) do
  link = @web.find '#menu-item-1154'
  agent_link = link.find_element(:css, 'a')
  href = agent_link.attribute(:href)
  agent_id = href.split('/').last
  for_real_agent_id = agent_id.split('-').first
  result = @api.get_agent_details for_real_agent_id
  expect(result['City'] == 'Charleston')
end

And(/^I click on the first property$/) do
  results = @web.wait_for '.js-load-results'
  prop1 = results.find_elements(:css, '.bt-listing-teaser__view-details').first
  prop1.click
  @web.wait_for '.bt-back-to-search'
end

And(/^I go back$/) do
  back = @web.find '.bt-back-to-search'
  back.click

end

And(/^I click on the second property$/) do
  results = @web.wait_for '.js-load-results'
  prop2 = results.find_elements(:css, '.bt-listing-teaser__view-details')
  prop2[1].click
end

Then(/^I see a registration form$/) do
  reg_form = @web.wait_for '.bt-squeeze'
  email = reg_form.find_element(:name, 'email')
  email.send_keys (Faker::Internet.email)
end