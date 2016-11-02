fs = require 'fs-plus'
{CompositeDisposable} = require 'atom'
settings = require './settings'

configTemplate = """
  # groups:
  #   atom: [
  #     "~/github/atom"
  #     "~/github/text-buffer"
  #     "~/github/atom-keymap"
  #   ]
  #   sample: [
  #     "~/dir/hello-project"
  #     "~/dir/world-project"
  #   ]
  """

module.exports =
  config: settings.config

  activate: ->
    @view = new (require './view')
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'project-folder:add': => @view.start('add')
      'project-folder:remove': => @view.start('remove')
      'project-folder:open-config': => @openConfig()

  deactivate: ->
    @subscriptions.dispose()
    @view?.destroy?()
    {@subscriptions, @view} = {}

  openConfig: ->
    filePath = @view.getConfigPath()

    atom.workspace.open(filePath, searchAllPanes: true).then (editor) =>
      unless fs.existsSync(filePath)
        editor.setText(configTemplate)
        editor.save()

      @subscriptions.add editor.onDidSave =>
        @view.loadConfig()
