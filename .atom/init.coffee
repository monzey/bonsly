atom.commands.add 'atom-text-editor',
    'custom:insert-php-object-accessor': ->
        atom.workspace.getActiveTextEditor()?.insertText('->')
