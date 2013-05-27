require 'spec_helper'

describe 'openings/new' do

  before(:each) do

    assign(:opening, stub_model(Opening,
      :title => 'MyString'
    ).as_new_record)

    user = FactoryGirl.create(:user)

    controller.stub(:current_user) { user }

  end

  it 'renders new opening form' do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select 'form', :action => openings_path, :method => 'post' do
      assert_select 'input#opening_title', :name => 'opening[title]'
    end
  end
end
