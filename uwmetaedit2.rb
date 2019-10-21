#!/usr/bin/env ruby

require 'flammarion'
require 'yaml'
require 'mediainfo'
require 'pry'

# Check for windows
if Gem.win_platform?
  windows = true
else
  windows = false
end

#Set up/Load config
scriptPath = __dir__
configPath = scriptPath + "/uw-metaedit-config.txt"
unless File.exist?(configPath)
  configOptions = {
    originator: "",
    history1: "",
    history2: "",
    collection: ""
  }
  File.open(configPath, "w") { |file| file.write(configOptions.to_yaml) }
end

 configOptions = YAML.load(File.read(configPath))

def getOutputDir()
  if windows
    @outputDir = `powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.FolderBrowserDialog;$f.SelectedPath = 'C:\';$f.Description = 'Select Output Directory';$f.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))|Out-Null;$f.SelectedPath"`.strip + '\\'
  else
    @outputDir = `zenity --file-selection --directory`.strip + '/'
  end
end

def getDerivDir()
  if windows
    derivDir = `powershell "Add-Type -AssemblyName System.windows.forms|Out-Null;$f=New-Object System.Windows.Forms.FolderBrowserDialog;$f.SelectedPath = 'C:\';$f.Description = 'Select Output Directory';$f.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))|Out-Null;$f.SelectedPath"`.strip + '\\'
  else
    derivDir = `zenity --file-selection --directory`.strip + '/'
  end
end

# Set up config variables
unless configOptions['originator'].nil?
  originator = configOptions['originator']
else
  originator = 'Originator'
end
unless configOptions['history1'].nil?
  history1 = configOptions['history1']
else
  history1 = 'Encoding History Line 1'
end
unless configOptions['history2'].nil?
  history2 = configOptions['history2']
else
  history2 = 'Encoding History Line 2'
end
unless configOptions['collection'].nil?
  collection = configOptions['collection']
else
  collection = 'Collection Number(s)'
end

if ARGV.length.positive?
  puts 'HELLO WORLD'
else
  window = Flammarion::Engraving.new
  window.image("")
  window.title("Welcome to UW Metaedit 2.0")
  window.pane("BEXT").puts("BEXT Info", replace:true)
  window.pane("BEXT").input(originator)
  window.pane("BEXT").input(history1)
  window.pane("BEXT").input(history2)
  window.pane("Items").orientation = :horizontal
  window.pane("Items").puts("Item Info", replace:true)
  window.pane("Items").input(collection)
  window.pane("Items").input("Item Number")
  window.wait_until_closed
end