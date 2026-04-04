class AddPipelineStageToJobApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :job_applications, :pipeline_stage, :string, default: "applied"
  end
end
