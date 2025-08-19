When('I open the main page') do
  visit '/'
end

Then('I should see the title') do
  expect(page).to have_content('Прогноз погоды')
end

Then('I should see the default cities') do
  expect(page).to have_content('Москва')
  expect(page).to have_content('Санкт-Петербург')
end

Then('I should see the table headers') do
  expect(page).to have_selector('th', text: 'Время')
  expect(page).to have_selector('th', text: 'Температура, °C')
end

Then('I should see time entries') do
  expect(page).to have_selector('time.js-local-time[data-utc]', minimum: 1)
end

Then('I should see temperatures') do
  expect(page).to have_selector('td', minimum: 1)
end
