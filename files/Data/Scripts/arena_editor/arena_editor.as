void Init(string levelName) {}
void ReceiveMessage(string msg) {}
void Update(int paused) {  }
void SetWindowDimensions(int w, int h){}

int spawnIdCounter = 0;

const array<string> weapons = {
    "No weapon",
    "Knife",
    "Big sword",
    "Sword",
    "Any"
};

const array<string> weaponsValues = {
    "none",
    "knife",
    "big_sword",
    "sword",
    "any"
};

const array<string> types = {
    "Any type",
    "Guard",
    "Raider"
};

const array<string> typesValues = {
    "any",
    "guard",
    "raider"
};

class Editor {
    array<Battle@> battles;

    void fromJSON(JSONValue value) {
        auto battles = value["battles"];

        for (uint i = 0; i < battles.size(); i++) {
            auto battle = battles[i];
            Battle new;
            new.fromJSON(battle);

            this.battles.insertLast(new);
        }
    }

    JSONValue toJSON() {
        JSONValue result;

        result["battles"] = JSONValue();

        for (uint i = 0; i < battles.size(); i++) {
            auto battle = battles[i];

            result["battles"][i] = battle.toJSON();
        }

        return result;
    }

    void draw(array<string> locations) {
        ImGui_Begin("Arena battle editor");

        if (ImGui_TreeNodeEx("Battles", ImGuiTreeNodeFlags_DefaultOpen)) {
            if (ImGui_Button("Add battle")) {
                battles.insertLast(Battle());
            }

            ImGui_Unindent();

            for (uint i = 0; i < battles.size(); i++) {
                auto battle = battles[i];

                if (ImGui_Button("X###battleRemove" + i)) {
                    battles.removeAt(i);
                    i--;
                    continue;
                }

                ImGui_SameLine();
                
                if (ImGui_TreeNode("battle" + i, battle.name)) {
                    battle.draw(locations);
                    ImGui_TreePop();
                }
            }

            ImGui_TreePop();
        }

        ImGui_End();
    }
}

class Battle {
    string name = "Unknown battle";
    string intro = "Let the battle begin!";
    int rounds = 1;

    array<Item@> items;
    array<Team@> teams;

    void fromJSON(JSONValue value) {
        name = value["name"].asString();
        intro = value["attributes"]["intro"].asString();
        rounds = atoi(value["attributes"]["rounds"].asString()); // Jesus why is it a string?

        auto items = value["items"];

        for (uint i = 0; i < items.size(); i++) {
            auto item = items[i];
            Item new;
            new.fromJSON(item);

            this.items.insertLast(new);
        }

        auto teams = value["teams"];

        for (uint i = 0; i < teams.size(); i++) {
            auto team = teams[i];
            Team new;
            new.fromJSON(team);

            this.teams.insertLast(new);
        }
    }

    JSONValue toJSON() {
        JSONValue result;

        result["name"] = JSONValue(name);
        result["attributes"]["intro"] = JSONValue(intro);
        result["attributes"]["rounds"] = JSONValue(rounds);

        result["items"] = JSONValue();

        for (uint i = 0; i < items.size(); i++) {
            auto item = items[i];

            result["items"][i] = item.toJSON();
        }

        result["teams"] = JSONValue();

        for (uint i = 0; i < teams.size(); i++) {
            auto team = teams[i];

            result["teams"][i] = team.toJSON();
        }

        return result;
    }

    void draw(array<string> locations) {
        ImGui_Indent();

        ImGui_SetTextBuf(name);

        if (ImGui_InputText("Name")) {
            name = ImGui_GetTextBuf();
        }

        ImGui_SetTextBuf(intro);

        if (ImGui_InputText("Intro")) {
            intro = ImGui_GetTextBuf();
        }

        ImGui_DragInt("Rounds", rounds, v_min: 1, v_max: 16);

        if (ImGui_TreeNode("items", "Items (" + items.size() + ")")) {
            if (ImGui_Button("Add item")) {
                items.insertLast(Item());
            }

            for (uint i = 0; i < items.size(); i++) {
                auto item = items[i];

                if (ImGui_Button("X###itemRemove" + i)) {
                    items.removeAt(i);
                    i--;
                    continue;
                }

                ImGui_SameLine();

                if (ImGui_TreeNode("item" + i, "Item " + (i + 1) + " - " + item.type)) {
                    item.draw(locations);

                    ImGui_TreePop();
                }
            }

            ImGui_TreePop();
        }

        if (ImGui_TreeNode("teams", "Teams (" + teams.size() + ")")) {
            if (ImGui_Button("Add team")) {
                teams.insertLast(Team());
            }

            for (uint i = 0; i < teams.size(); i++) {
                auto team = teams[i];

                if (ImGui_Button("X###teamRemove" + i)) {
                    teams.removeAt(i);
                    i--;
                    continue;
                }

                ImGui_SameLine();
                
                if (ImGui_TreeNode("team" + i, "Team " + (i + 1) + " with " + team.members.size() + " members")) {
                    team.draw(locations);

                    ImGui_TreePop();
                }
            }

            ImGui_TreePop();
        }

        ImGui_Unindent();
    }
}

class Item {
    string spawn;
    string type;

    void fromJSON(JSONValue value) {
        spawn = value["location"].asString();
        type = value["type"].asString();
    }

    JSONValue toJSON() {
        JSONValue result;

        result["location"] = JSONValue(spawn);
        result["type"] = JSONValue(type);

        return result;
    }

    void draw(array<string> locations) {
        int selectedWeapon = weaponsValues.length() - 1;
        int selectedLocation = -1;

        for (uint k = 0; k < locations.size(); k++) {
            if (locations[k] == spawn) {
                selectedLocation = k;
                break;
            }
        }

        for (uint k = 0; k < weaponsValues.size(); k++) {
            if (weaponsValues[k] == type) {
                selectedWeapon = k;
                break;
            }
        }

        ImGui_PushItemWidth(200);

        if (ImGui_Combo("Spawn Point", selectedLocation, locations)) {
            spawn = locations[selectedLocation];
        }

        if (ImGui_Combo("Type", selectedWeapon, weapons)) {
            type = weaponsValues[selectedWeapon];
        }

        ImGui_PopItemWidth();
    }
}

class Team {
    array<Member@> members;

    void fromJSON(JSONValue value) {
        auto members = value["members"];

        for (uint i = 0; i < members.size(); i++) {
            auto member = members[i];
            Member new;
            new.fromJSON(member);

            this.members.insertLast(new);
        }
    }

    JSONValue toJSON() {
        JSONValue result;

        result["members"] = JSONValue();

        for (uint i = 0; i < members.size(); i++) {
            auto member = members[i];

            result["members"][i] = member.toJSON();
        }

        return result;
    }

    void draw(array<string> locations) {
        if (ImGui_Button("Add member")) {
            members.insertLast(Member());
        }

        for (uint i = 0; i < members.size(); i++) {
            auto member = members[i];
            
            if (ImGui_Button("X###memberRemove" + i)) {
                members.removeAt(i);
                i--;
                continue;
            }

            ImGui_SameLine();
                
            if (ImGui_TreeNode("Member " + (i + 1))) {
                member.draw(locations);

                ImGui_TreePop();
            }
        }
    }
}

class Member {
    string spawn;
    string weapon;
    string type;
    bool player;

    void fromJSON(JSONValue value) {
        spawn = value["location"].asString();
        weapon = value["weapon"].asString();
        type = value["type"].asString();
        player = value["player"].asString() == "maybe";
    }

    JSONValue toJSON() {
        JSONValue result;

        result["location"] = JSONValue(spawn);
        result["weapon"] = JSONValue(weapon);
        result["type"] = JSONValue(type);
        result["player"] = JSONValue(player ? "maybe" : "notaplayer");
        result["id"] = JSONValue(spawnIdCounter++); // Only needed due to faulty arena code implementation

        return result;
    }

    void draw(array<string> locations) {
        int selectedLocation = -1;

        for (uint k = 0; k < locations.size(); k++) {
            if (locations[k] == spawn) {
                selectedLocation = k;
                break;
            }
        }

        int selectedWeapon = weaponsValues.length() - 1;

        for (uint k = 0; k < weaponsValues.size(); k++) {
            if (weaponsValues[k] == weapon) {
                selectedWeapon = k;
                break;
            }
        }

        int selectedType = 0;

        for (uint k = 0; k < typesValues.size(); k++) {
            if (typesValues[k] == type) {
                selectedType = k;
                break;
            }
        }

        ImGui_PushItemWidth(200);

        if (ImGui_Combo("Spawn Point", selectedLocation, locations)) {
            spawn = locations[selectedLocation];
        }

        if (ImGui_Combo("Weapon", selectedWeapon, weapons)) {
            weapon = weaponsValues[selectedWeapon];
        }

        if (ImGui_Combo("Type", selectedType, types)) {
            type = typesValues[selectedType];
        }

        ImGui_Checkbox("Can spawn a player", player);

        ImGui_PopItemWidth();
    }
}

void DrawBattleEditor(ScriptParams@ params, array<string> locations) {
    auto json = params.GetJSON("Battles");
    auto data = json.getRoot()["data"];

    spawnIdCounter = 0;

    Editor editor;
    editor.fromJSON(data);
    editor.draw(locations);
    json.getRoot()["data"] = editor.toJSON();

    if (params.HasParam("Battles")) {
        params.Remove("Battles");
    }

    params.AddJSON("Battles", json);
}

void DrawGUI() {
    if (!EditorModeActive()) {
        return;
    }

    auto indices = GetObjectIDs();
    array<string> locations;
    int battleEditorId = -1;

    for (uint i = 0; i < indices.size(); i++) {
        if (!ObjectExists(i)) {
            continue;
        }
        
        auto object = ReadObjectFromID(indices[i]);
        auto params = object.GetScriptParams();

        if (params.HasParam("Name")) {
            if (object.IsSelected()) {
                if (params.GetString("Name") == "arena_battle") {
                    battleEditorId = indices[i];
                }
            }

            if (params.GetString("Name") == "arena_spawn" && params.HasParam("LocName")) {
                locations.insertLast(params.GetString("LocName"));
            }
        }
    }

    if (battleEditorId != -1) {
        auto battleEditor = ReadObjectFromID(battleEditorId);
        DrawBattleEditor(battleEditor.GetScriptParams(), locations);
    }
}