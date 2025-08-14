When('I open the main page') do
  visit '/'
end

Then('I should see the title') do
  expect(page).to have_content('Прогноз погоды')
end


