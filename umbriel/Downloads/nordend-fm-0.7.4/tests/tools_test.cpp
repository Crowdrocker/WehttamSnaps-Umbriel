// The development tools' command lines: --help answers, an unknown option is refused, and nothing
// is written or crashes on the way (nordend-snapshot once wrote a PPM called "--help",
// nordend-decode crashed on it and called an ORF "unknown").

#include <array>
#include <cstddef>
#include <fcntl.h>
#include <filesystem>
#include <initializer_list>
#include <spawn.h>
#include <string>
#include <string_view>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <vector>

#include <doctest/doctest.h>

#include "temp_dir.hpp"

extern char** environ;  // NOLINT(readability-redundant-declaration): POSIX, not in a header

namespace {

struct Ran {
    std::string out;  // stdout and stderr together
    int status{0};    // the wait status
};

// Runs program with args in the folder at, and collects what it printed and how it ended.
Ran run(const std::string& program, std::initializer_list<std::string> args,
        const std::filesystem::path& at) {
    std::array<int, 2> ends{-1, -1};
    REQUIRE(::pipe2(ends.data(), O_CLOEXEC) == 0);
    posix_spawn_file_actions_t actions{};
    posix_spawn_file_actions_init(&actions);
    posix_spawn_file_actions_adddup2(&actions, ends[1], STDOUT_FILENO);
    posix_spawn_file_actions_adddup2(&actions, ends[1], STDERR_FILENO);
    posix_spawn_file_actions_addchdir_np(&actions, at.c_str());
    std::vector<std::string> words{program};
    words.insert(words.end(), args);
    std::vector<char*> argv;
    argv.reserve(words.size() + 1);
    for (std::string& word : words) {
        argv.push_back(word.data());
    }
    argv.push_back(nullptr);
    pid_t pid = -1;
    const int spawned =
        ::posix_spawn(&pid, program.c_str(), &actions, nullptr, argv.data(), environ);
    posix_spawn_file_actions_destroy(&actions);
    ::close(ends[1]);
    REQUIRE(spawned == 0);
    Ran result;
    std::array<char, 512> buffer{};
    ssize_t got = 0;
    while ((got = ::read(ends[0], buffer.data(), buffer.size())) > 0) {
        result.out.append(buffer.data(), static_cast<std::size_t>(got));
    }
    ::close(ends[0]);
    ::waitpid(pid, &result.status, 0);
    return result;
}

int exit_code(const Ran& ran) { return WIFEXITED(ran.status) ? WEXITSTATUS(ran.status) : -1; }

bool contains(const std::string& text, std::string_view part) {
    return text.find(part) != std::string::npos;
}

}  // namespace

TEST_CASE("tools: --help prints the usage and writes nothing") {
    const nordend::test::TempDir dir;
    for (const char* option : {"--help", "-h"}) {
        INFO(option);
        const Ran snapshot = run(NORDEND_SNAPSHOT_TOOL, {option}, dir.path);
        CHECK(exit_code(snapshot) == 0);
        CHECK(contains(snapshot.out, "usage: nordend-snapshot"));
        const Ran decode = run(NORDEND_DECODE_TOOL, {option}, dir.path);
        CHECK(exit_code(decode) == 0);
        CHECK(contains(decode.out, "usage: nordend-decode"));
    }
    CHECK(std::filesystem::is_empty(dir.path));
}

TEST_CASE("tools: an unknown option is refused, not taken for a file") {
    const nordend::test::TempDir dir;
    const Ran snapshot = run(NORDEND_SNAPSHOT_TOOL, {"--nope"}, dir.path);
    CHECK(exit_code(snapshot) == 2);
    CHECK(contains(snapshot.out, "usage: nordend-snapshot"));
    const Ran decode = run(NORDEND_DECODE_TOOL, {"--nope"}, dir.path);
    CHECK(exit_code(decode) == 2);
    CHECK(contains(decode.out, "usage: nordend-decode"));
    CHECK(std::filesystem::is_empty(dir.path));
}

TEST_CASE("nordend-decode: a missing file is a failure, not a crash") {
    const nordend::test::TempDir dir;
    const Ran decode = run(NORDEND_DECODE_TOOL, {"--runs", "1", "missing.png"}, dir.path);
    CHECK(exit_code(decode) == 1);
    CHECK(contains(decode.out, "missing.png: "));
}

TEST_CASE("nordend-decode: a raw without the TIFF magic goes the camera raw way") {
    const nordend::test::TempDir dir;
    // An ORF's magic and nothing behind it: load() calls it damaged; decode() called it unknown.
    dir.write("cut.orf", std::string{"IIRO\x08\0\0\0", 8});
    const Ran decode = run(NORDEND_DECODE_TOOL, {"--runs", "1", "cut.orf"}, dir.path);
    CHECK(exit_code(decode) == 1);
    CHECK(contains(decode.out, "(camera raw)"));
    CHECK_FALSE(contains(decode.out, "unknown"));
}
