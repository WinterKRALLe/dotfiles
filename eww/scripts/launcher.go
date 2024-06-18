package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

const (
	cacheFile  = "~/.cache/apps.json"
	desktopDir = "/usr/share/applications"
)

type Entry struct {
	Name    string `json:"name"`
	Icon    string `json:"icon"`
	Desktop string `json:"desktop"`
}

type Entries struct {
	Apps     []Entry `json:"apps"`
	Search   bool    `json:"search"`
	Filtered []Entry `json:"filtered"`
}

var iconDirs = []string{
	"/usr/share/icons",
	"/usr/share/pixmaps",
	filepath.Join(os.Getenv("HOME"), ".local/share/icons"),
}

func getCurrentIconTheme() string {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		fmt.Println("Error getting user home directory:", err)
		return ""
	}

	// Possible settings file paths
	settingsFiles := []string{
		filepath.Join(homeDir, ".config", "gtk-3.0", "settings.ini"),
		filepath.Join(homeDir, ".config", "gtk-4.0", "settings.ini"),
	}

	for _, settingsFile := range settingsFiles {
		if _, err := os.Stat(settingsFile); err == nil {
			file, err := os.Open(settingsFile)
			if err != nil {
				fmt.Println("Error opening settings file:", err)
				return ""
			}
			defer file.Close()

			scanner := bufio.NewScanner(file)
			for scanner.Scan() {
				line := scanner.Text()
				if strings.HasPrefix(line, "gtk-icon-theme-name=") {
					parts := strings.SplitN(line, "=", 2)
					if len(parts) == 2 {
						return strings.TrimSpace(parts[1])
					}
				}
			}
			if err := scanner.Err(); err != nil {
				fmt.Println("Error reading settings file:", err)
				return ""
			}
		}
	}

	return ""
}

func findIconPath(iconName string) string {
	iconTheme := getCurrentIconTheme()
	if iconTheme == "" {
		iconTheme = "hicolor" // Fallback to hicolor if no theme is set
	}

	// Check if the iconName is an absolute path
	if filepath.IsAbs(iconName) {
		if _, err := os.Stat(iconName); err == nil {
			return iconName
		}
		return ""
	}

	// Check in each icon directory
	for _, dir := range iconDirs {
		// Consider multiple possible extensions
		for _, ext := range []string{".png", ".svg", ".xpm"} {
			// Check within the current icon theme directory
			iconThemePath := filepath.Join(dir, iconTheme, "apps", "scalable", iconName+ext)
			if _, err := os.Stat(iconThemePath); err == nil {
				return iconThemePath
			}
			// Check in the default directory
			iconPath := filepath.Join(dir, iconName+ext)
			if _, err := os.Stat(iconPath); err == nil {
				return iconPath
			}
		}
	}

	// Return empty string if icon not found
	return ""
}

func getDesktopEntries() Entries {
	desktopFiles, _ := filepath.Glob(filepath.Join(desktopDir, "*.desktop"))
	entries := Entries{}
	uniqueEntries := make(map[string]struct{})

	for _, filePath := range desktopFiles {
		parser := NewConfigParser(filePath)
		appName := parser.Get("Desktop Entry", "Name")
		iconName := parser.Get("Desktop Entry", "Icon")

		// Skip if NoDisplay=true
		if parser.Get("Desktop Entry", "NoDisplay") == "true" {
			continue
		}

		// Ensure uniqueness by using app name as a key
		if _, exists := uniqueEntries[appName]; exists {
			continue
		}
		uniqueEntries[appName] = struct{}{}

		// Resolve the full icon path
		iconPath := findIconPath(iconName)

		entry := Entry{Name: appName, Icon: iconPath, Desktop: filePath}
		entries.Apps = append(entries.Apps, entry)
	}

	return entries
}

func readCache() []Entry {
	cachePath, _ := filepath.Abs(cacheFile)
	data, err := os.ReadFile(cachePath)
	if err != nil {
		fmt.Printf("Error reading cache file: %v\n", err)
		return []Entry{}
	}

	var entries []Entry
	json.Unmarshal(data, &entries)
	return entries
}

func writeCache(entries []Entry) {
	cachePath, _ := filepath.Abs(cacheFile)
	jsonData, _ := json.MarshalIndent(entries, "", "  ")
	os.WriteFile(cachePath, jsonData, 0644)
}

func filterEntries(entries Entries, query string) []Entry {
	filteredData := make([]Entry, 0)
	for _, entry := range entries.Apps {
		if strings.Contains(strings.ToLower(entry.Name), strings.ToLower(query)) {
			filteredData = append(filteredData, entry)
		}
	}
	return filteredData
}

func updateEww(entries Entries) {
	jsonData, _ := json.Marshal(entries)
	exec.Command("eww", "update", "apps="+string(jsonData)).Run()
}

func main() {
	args := os.Args[1:]

	if len(args) > 1 {
		switch args[0] {
		case "--query":
			query := args[1]
			if query == "" {
				entries := getDesktopEntries()
				updateEww(entries)
				return
			}
			entries := getDesktopEntries()
			filtered := filterEntries(entries, query)
			updateEww(Entries{Apps: entries.Apps, Search: true, Filtered: filtered})
		default:
			entries := getDesktopEntries()
			updateEww(entries)
		}
	} else {
		entries := getDesktopEntries()
		updateEww(entries)
	}
}

// ConfigParser is a simple implementation for parsing .desktop files
type ConfigParser struct {
	Values map[string]map[string]string
}

func NewConfigParser(filePath string) *ConfigParser {
	data, _ := os.ReadFile(filePath)
	lines := strings.Split(string(data), "\n")
	parser := &ConfigParser{Values: make(map[string]map[string]string)}
	var currentSection string
	for _, line := range lines {
		if strings.HasPrefix(line, "[") && strings.HasSuffix(line, "]") {
			currentSection = line[1 : len(line)-1]
			parser.Values[currentSection] = make(map[string]string)
		} else if strings.Contains(line, "=") {
			parts := strings.SplitN(line, "=", 2)
			key := strings.TrimSpace(parts[0])
			value := strings.TrimSpace(parts[1])
			if currentSection != "" {
				parser.Values[currentSection][key] = value
			}
		}
	}
	return parser
}

func (cp *ConfigParser) Get(section, key string) string {
	if val, ok := cp.Values[section][key]; ok {
		return val
	}
	return ""
}
