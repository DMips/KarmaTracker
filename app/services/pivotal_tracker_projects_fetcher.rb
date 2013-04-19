class PivotalTrackerProjectsFetcher

  def fetch_projects(identity)
    Rails.logger.info "Fetching projects for PT identity #{identity.api_key}"
    uri = "https://www.pivotaltracker.com/services/v4/projects"
    doc = Nokogiri::XML(open(uri, 'X-TrackerToken' => identity.api_key))

    doc.xpath('//project').each do |data|
      name = data.xpath('./name').first.content
      source_identifier = data.xpath('./id').first.content

      project = Project.where("source_name = 'Pivotal Tracker' AND source_identifier = ?", source_identifier).
        first_or_initialize(source_name: 'Pivotal Tracker', source_identifier: source_identifier)
      project.name = name
      project.save

      fetch_identities project, data
      fetch_tasks project, identity
    end
    Rails.logger.info "Successfully updated list of projects for PT identity #{identity.api_key}"
  end

  def fetch_identities(project, data)
    Rails.logger.info "Fetching identities for PT project #{project.source_identifier}"
    identities = []
    data.xpath('./memberships/membership').each do |membership|
      pt_id = membership.xpath('./member/person/id').first.content
      identity = PivotalTrackerIdentity.find_by_source_id(pt_id)
      identities << identity if identity.present?
    end

    identities.each do |identity|
      project.identities << identity unless project.identities.include?(identity)
    end

    project.identities.each do |identity|
      project.identities.delete(identity) unless identities.include?(identity)
    end
    Rails.logger.info "Successfully updated list of identities for PT project #{project.source_identifier}"
  end

  def fetch_tasks(project, identity)
    Rails.logger.info "Fetching tasks for PT project #{project.source_identifier}"
    uri = "https://www.pivotaltracker.com/services/v4/projects/#{project.source_identifier}/stories"
    doc = Nokogiri::XML(open(uri, 'X-TrackerToken' => identity.api_key))

    doc.xpath('//story').each do |data|
      name = data.xpath('./name').first.content
      source_identifier = data.xpath('./id').first.content
      story_type = data.xpath('./story_type').first.content
      current_state = data.xpath('./current_state').first.content

      task = Task.where("source_name = 'Pivotal Tracker' AND source_identifier = ?", source_identifier).
        first_or_initialize(source_name: 'Pivotal Tracker', source_identifier: source_identifier)
      task.name = name
      task.story_type = story_type
      task.current_state = current_state
      task.project = project
      task.save
    end
    fetch_current_tasks project, identity
    Rails.logger.info "Successfully updated list of tasks for PT project #{project.source_identifier}"
  end

  def fetch_current_tasks(project, identity)
    Rails.logger.info "Fetching current tasks for PT project #{project.source_identifier}"
    uri = "https://www.pivotaltracker.com/services/v4/projects/#{project.source_identifier}/iterations/current"
    doc = Nokogiri::XML(open(uri, 'X-TrackerToken' => identity.api_key))

    current_tasks_ids = []
    doc.xpath('/iterations/iteration').first.xpath('./stories/story').each do |story|
      story_id = story.xpath('./id').first.content
      current_tasks_ids << story_id
    end
    project.tasks.where('source_identifier NOT IN (?)', current_tasks_ids).update_all('current_task = FALSE')
    project.tasks.where('source_identifier IN (?)', current_tasks_ids).update_all('current_task = TRUE')
    Rails.logger.info "Successfully updated list of current tasks for PT project #{project.source_identifier}"
  end
end