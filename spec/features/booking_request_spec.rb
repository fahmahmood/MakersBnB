feature 'Booking request'  do

  scenario 'user can click on an item in the space list and see more information' do
    sign_up
    list_a_space
    visit '/spaces'
    click_link '1 bed flat'
    expect(current_path).to eq('/spaces/details/1')
    expect(page).to have_content('cozy flat in central London')
  end

  scenario 'user can enter prefered date and request a space' do
    expect { request_space }.to change(Request, :count).by(1)
    expect(current_path).to eq('/requests')
    expect(page).to have_content('Requests')
  end

  scenario 'raises error if booking date is blank' do
    expect { request_space(check_in_date: '') }.not_to change(Request, :count)
    expect(page).to have_content('Check in date must not be blank')
  end

  scenario 'raises error if date selected is not within range of available dates' do
    expect { request_space(check_in_date: '01/01/2990') }.not_to change(Request, :count)
    expect(page).to have_content('Check in date must be within available dates')
  end

  scenario 'shows requests user has received' do
    sign_up
    list_a_space
    user = User.create(email: "user2@email.com", password: "cherries", password_confirmation: "cherries")
    space = Space.first
    request = Request.new(check_in_date: "01/02/2030")
    request.user_id = user.id
    request.space_id = space.id
    request.save
    visit '/requests'
    within "ul#requests_received" do
      expect(page).to have_content "user2@email.com"
      expect(page).to have_content "01/02/2030"
      expect(page).to have_content "1 bed flat"
    end
  end

  scenario 'user can confirm a request received' do
    sign_up
    list_a_space
    user = User.create(email: "user2@email.com", password: "cherries", password_confirmation: "cherries")
    space = Space.first
    request = Request.new(check_in_date: "01/02/2030")
    request.user_id = user.id
    request.space_id = space.id
    request.save
    request_id = request.id

    visit '/requests'

    find('#requests_received').first(:link).click

    expect(current_path).to eq "/requests/review/#{request.id}"
    click_button 'Confirm Request'
    expect(page.status_code).to eq 200
    within "ul#requests_received" do
      expect(page).not_to have_content "Not Confirmed"
    end
    request_now = Request.get(request_id)
    expect(request_now.confirmed).to be true
  end
end
