RSpec.describe Devise::Models::Async do
  subject { create_admin }

  before :each do
    ActiveJob::Base.queue_adapter = :test
  end

  it 'enqueues notifications immediately when the model did not change' do
    subject

    expect(ActionMailer::DeliveryJob).to have_been_enqueued
  end

  it 'forwards the correct data to the job' do
    subject

    job_data = ActiveJob::Base.queue_adapter.enqueued_jobs.first[:args]
    expected_job_data = ['Devise::Mailer', 'confirmation_instructions', subject.send(:confirmation_token)]

    expect(job_data).to include(*expected_job_data)
  end

  context 'in a database transaction' do
    subject do
      Admin.transaction do
        @admin = create_admin
      end
    end

    it 'enqueues notifications immediately when the model did not change' do
      pending 'Re-write with sending notificaitons manually.'
      subject

      expect(ActionMailer::DeliveryJob).to have_been_enqueued
    end

    it 'forwards the correct data to the job' do
      pending 'Re-write with sending notificaitons manually.'
      subject

      job_data = ActiveJob::Base.queue_adapter.enqueued_jobs.first[:args]
      expected_job_data = ['Devise::Mailer', 'confirmation_instructions', @admin.send(:confirmation_token)]

      expect(job_data).to include(*expected_job_data)
    end
  end

  context 'with changed model' do
    let(:admin) { create_admin }

    before :each do
      admin
    end

    context 'without saving the model' do
      subject do
        admin[:username] = "changed_username"
        admin.send_confirmation_instructions

        admin.send(:devise_pending_notifications)
      end

      it 'accumulates a pending notification to be sent after commit' do
        Admin.transaction do
          pending_notification = subject

          expect(pending_notification.size).to eq 1
          expect(pending_notification.first).to eq([:confirmation_instructions, [admin.send(:confirmation_token), {}]])
        end
      end

      it 'does not enqueue another job' do
        Admin.transaction do
          expect {
            subject
          }.to_not have_enqueued_job(ActionMailer::DeliveryJob)
        end
      end
    end

    context 'with saving the model' do
      subject do
        admin[:username] = "changed_username"
        admin.send_confirmation_instructions

        admin.send(:devise_pending_notifications)
        admin.save
      end

      it 'does enqueue another job' do
        pending
        Admin.transaction do
          expect {
            subject
          }.to have_enqueued_job(ActionMailer::DeliveryJob)
        end
      end
    end

    # it "triggers the enqueued notifications on save" do
    #   admin = create_admin
    #   Admin.transaction do
    #     admin[:username] = "changed_username"
    #     admin.send_confirmation_instructions

    #     mailers = admin.send(:devise_pending_notifications) # [:confirmation_instructions, ["RUQUib67wLcCiEyZMwfx", {}]]
    #     mailers.size.must_equal 1

    #     mailer = mailers.first
    #     mailer.size.must_equal 2
    #     mailer.first.must_equal :confirmation_instructions
    #     mailer.last.must_be_instance_of Array

    #     admin.save
    #     Worker.expects(:enqueue).with(:confirmation_instructions, "Admin", admin.id.to_s, instance_of(String), {})
    #   end
    # end
  end

  context 'when devise async is disabled' do
    before :each do
      Devise::Async.enabled = false
    end

    it 'does not enqueue a job' do
      expect {
        subject
      }.to_not have_enqueued_job(ActionMailer::DeliveryJob)
    end

    it 'does not accumulate pending notifications' do
      expect(subject.send(:devise_pending_notifications)).to be_empty
    end
  end
end
