describe AssignmentsController do
  # copied from the controller
  DEFAULT_FIELDS = [:short_identifier, :description,
                    :due_date, :message, :group_min, :group_max,
                    :tokens_per_period, :allow_web_submits,
                    :student_form_groups, :remark_due_date,
                    :remark_message, :assign_graders_to_criteria,
                    :enable_test, :enable_student_tests, :allow_remarks,
                    :display_grader_names_to_students,
                    :display_median_to_students, :group_name_autogenerated,
                    :is_hidden, :vcs_submit, :has_peer_review].freeze

  before :each do
    # Authenticate user is not timed out, and has administrator rights.
    allow(controller).to receive(:session_expired?).and_return(false)
    allow(controller).to receive(:logged_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(build(:admin))
  end

  let(:annotation_category) { FactoryBot.create(:annotation_category) }

  context '#upload' do
    include_examples 'a controller supporting upload' do
      let(:params) { {} }
    end

    before :each do
      # We need to mock the rack file to return its content when
      # the '.read' method is called to simulate the behaviour of
      # the http uploaded file
      @file_good = fixture_file_upload('files/assignments/form_good.csv', 'text/csv')
      allow(@file_good).to receive(:read).and_return(
        File.read(fixture_file_upload('files/assignments/form_good.csv', 'text/csv'))
      )
      @file_good_yml = fixture_file_upload('files/assignments/form_good.yml', 'text/yaml')
      allow(@file_good_yml).to receive(:read).and_return(
        File.read(fixture_file_upload('files/assignments/form_good.yml', 'text/yaml'))
      )

      @file_invalid_column = fixture_file_upload('files/assignments/form_invalid_column.csv', 'text/csv')
      allow(@file_invalid_column).to receive(:read).and_return(
        File.read(fixture_file_upload('files/assignments/form_invalid_column.csv', 'text/csv'))
      )

      # This must line up with the second entry in the file_good
      @test_asn1 = 'ATest1'
      @test_asn2 = 'ATest2'
    end

    it 'accepts a valid file' do
      post :upload, params: { upload_file: @file_good }

      expect(response.status).to eq(302)
      test1 = Assignment.find_by(short_identifier: @test_asn1)
      expect(test1).to_not be_nil
      test2 = Assignment.find_by(short_identifier: @test_asn2)
      expect(test2).to_not be_nil
      expect(flash[:error]).to be_nil
      expect(flash[:success].map { |f| extract_text f }).to eq([I18n.t('upload_success',
                                                                       count: 2)].map { |f| extract_text f })
      expect(response).to redirect_to(action: 'index',
                                      controller: 'assignments')
    end

    it 'accepts a valid YAML file' do
      post :upload, params: { upload_file: @file_good_yml }

      expect(response.status).to eq(302)
      test1 = Assignment.find_by_short_identifier(@test_asn1)
      expect(test1).to_not be_nil
      test2 = Assignment.find_by_short_identifier(@test_asn2)
      expect(test2).to_not be_nil
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(action: 'index', controller: 'assignments')
    end

    it 'does not accept files with invalid columns' do
      post :upload, params: { upload_file: @file_invalid_column }

      expect(response.status).to eq(302)
      expect(flash[:error]).to_not be_empty
      test = Assignment.find_by_short_identifier(@test_asn2)
      expect(test).to be_nil
      expect(response).to redirect_to(action: 'index',
                                      controller: 'assignments')
    end
  end

  context 'CSV_Downloads' do
    let(:csv_options) do
      { type: 'text/csv', filename: 'assignments.csv', disposition: 'attachment' }
    end
    let!(:assignment) { create(:assignment) }

    it 'responds with appropriate status' do
      get :download, params: { format: 'csv' }
      expect(response.status).to eq(200)
    end

    # parse header object to check for the right disposition
    it 'sets disposition as attachment' do
      get :download, params: { format: 'csv' }
      d = response.header['Content-Disposition'].split.first
      expect(d).to eq 'attachment;'
    end

    it 'expects a call to send_data' do
      # generate the expected csv string
      csv_data = []
      DEFAULT_FIELDS.map do |f|
        csv_data << assignment.send(f.to_s)
      end
      new_data = csv_data.join(',') + "\n"
      expect(@controller).to receive(:send_data).with(new_data, csv_options) {
        # to prevent a 'missing template' error
        @controller.head :ok
      }
      get :download, params: { format: 'csv' }
    end

    # parse header object to check for the right content type
    it 'returns text/csv type' do
      get :download, params: { format: 'csv' }
      expect(response.media_type).to eq 'text/csv'
    end

    # parse header object to check for the right file naming convention
    it 'filename passes naming conventions' do
      get :download, params: { format: 'csv' }
      filename = response.header['Content-Disposition'].split[1].split('"').second
      expect(filename).to eq 'assignments.csv'
    end
  end

  context 'YML_Downloads' do
    let(:yml_options) do
      { type: 'text/yml', filename: 'assignments.yml', disposition: 'attachment' }
    end
    let!(:assignment) { create(:assignment) }

    it 'responds with appropriate status' do
      get :download, params: { format: 'yml' }
      expect(response.status).to eq(200)
    end

    # parse header object to check for the right disposition
    it 'sets disposition as attachment' do
      get :download, params: { format: 'yml' }
      d = response.header['Content-Disposition'].split.first
      expect(d).to eq 'attachment;'
    end

    it 'expects a call to send_data' do
      # generate the expected yml string
      assignments = Assignment.all
      map = {}
      map[:assignments] = assignments.map do |assignment|
        m = {}
        DEFAULT_FIELDS.each do |f|
          m[f] = assignment.send(f)
        end
        m
      end
      map = map.to_yaml
      expect(@controller).to receive(:send_data).with(map, yml_options) {
        # to prevent a 'missing template' error
        @controller.head :ok
      }
      get :download, params: { format: 'yml' }
    end

    # parse header object to check for the right content type
    it 'returns text/yml type' do
      get :download, params: { format: 'yml' }
      expect(response.media_type).to eq 'text/yml'
    end

    # parse header object to check for the right file naming convention
    it 'filename passes naming conventions' do
      get :download, params: { format: 'yml' }
      filename = response.header['Content-Disposition'].split[1].split('"').second
      expect(filename).to eq 'assignments.yml'
    end
  end
end
