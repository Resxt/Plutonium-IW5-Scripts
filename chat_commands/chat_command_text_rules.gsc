#include scripts\chat_commands;

Init()
{
    CreateCommand(["27016", "27017"], "rules", "text", ["Do not camp", "Do not spawnkill", "Do not disrespect other players"], 1);
    CreateCommand(["27018"], "rules", "text", ["Leave your spot and don't camp after using a M.O.A.B", "Don't leave while being infected", "Do not disrespect other players"], 1);
}