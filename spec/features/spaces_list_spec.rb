feature 'List of spaces' do
  scenario 'user can see a list of spaces' do
    sign_up
    list_a_space
    visit '/spaces'
    expect(page.status_code).to eq 200
    within 'ul#spaces' do
      expect(page).to have_content('1 bed flat')
    end
  end

  scenario 'user add one space' do
    sign_up
    expect{ list_a_space }.to change(Space, :count).by(1)
  end

  scenario 'user tries to submit incomplete form' do
    sign_up
    expect{ list_a_space(name: "", description: "", price: "", available_from: "", available_until: "") }.not_to change(Space, :count)
    expect(page).to have_content('Name must not be blank')
    expect(page).to have_content('Description must not be blank')
    expect(page).to have_content('Price must not be blank')
    expect(page).to have_content('Available from must not be blank')
    expect(page).to have_content('Available until must not be blank')
  end

  scenario 'raises error if available_from is a past date' do
    sign_up
    expect{ list_a_space(available_from: pretty_yesterday) }.not_to change(Space, :count)
    expect(page).to have_content("The available from date must be in the future")
  end

  scenario 'raises error if available_until is prior to available_from' do
    sign_up
    expect{ list_a_space(available_until: '01/01/2030') }.not_to change(Space, :count)
    expect(page).to have_content("The until date must come after the from date")
  end

  scenario '"List a space" button takes to /spaces/new' do
    sign_up
    visit '/spaces'
    click_button 'List a Space'
    expect(current_path).to eq '/spaces/new'
    expect(page.status_code).to eq 200
  end
end
