feature 'User sign up' do
  scenario 'I can sign up as a new user' do
    expect { sign_up }.to change(User, :count).by(1)
    expect(page).to have_content('Welcome to MakersBnB, test@test.com')
    expect(User.first.email).to eq('test@test.com')
  end

  scenario 'requires a matching confirmation password' do
    expect { sign_up(password_confirmation: 'wrong') }.not_to change(User, :count)
  end

  scenario 'with a password that does not match' do
    expect { sign_up(password_confirmation: 'wrong') }.not_to change(User, :count)
    expect(current_path).to eq('/users')
    expect(page).to have_content 'Password does not match the confirmation'
  end

  scenario 'I cannot sign up with an existing email' do
    sign_up
    expect { sign_up }.to_not change(User, :count)
    expect(page).to have_content('Email is already taken')
  end

  scenario 'I cannot sign up withOUT an email address' do
    expect { sign_up(email: nil) }.to_not change(User, :count)
    expect(current_path).to eq('/users')
    expect(page).to have_content('Email must not be blank')
  end

  scenario 'I cannot sign up with an invalid email address' do
    expect { sign_up(email: 'invalid@email') }.to_not change(User, :count)
    expect(current_path).to eq('/users')
    expect(page).to have_content('Email has an invalid format')
  end

  scenario 'I cannot sign up with a blank password' do
    expect { sign_up(password: '', password_confirmation: '') }.to_not change(User, :count)
  end
end

feature 'User login' do
  scenario 'I want the login link to take me to the login page' do
    visit('/users/new')
    click_link('Log in')
    expect(current_path).to eq('/sessions/new')
    expect(page).to have_content('Log in to MakersBnB')
  end

  scenario 'I want to logs in and be taken to the spaces page' do
    user = User.create(email: 'sdawes@gmail.com', password: 'password', password_confirmation: 'password')
    log_in
    expect(current_path).to eq('/spaces')
    expect(page).to have_content("Welcome to MakersBnB, #{user.email}")
  end
end

feature 'User log out' do
  scenario 'I want to log out to end my session' do
    user = User.create(email: 'sdawes@gmail.com', password: 'password', password_confirmation: 'password')
    log_in
    click_link('Log out')
    expect(current_path).to eq('/users/new')
    expect(page).to have_content('Please sign up')
  end
end
