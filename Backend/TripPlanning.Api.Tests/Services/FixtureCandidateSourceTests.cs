using TripPlanning.Api.Services.Classes;

namespace TripPlanning.Api.Tests.Services
{
    public class FixtureCandidateSourceTests
    {
        [Fact]
        public async Task GetCandidatesAsync_ReturnsIstanbulFixtureCandidates()
        {
            var source = new FixtureCandidateSource();

            var candidates = await source.GetCandidatesAsync(
                "istanbul",
                CancellationToken.None);

            Assert.Equal(9, candidates.Count);

            Assert.All(candidates, candidate =>
            {
                Assert.Equal("istanbul", candidate.DestinationId);
                Assert.False(string.IsNullOrWhiteSpace(candidate.Id));
                Assert.False(string.IsNullOrWhiteSpace(candidate.Name));
                Assert.NotNull(candidate.CategoryIds);
            });
        }

        [Fact]
        public async Task GetCandidatesAsync_ReturnsRomeFixtureCandidates()
        {
            var source = new FixtureCandidateSource();

            var candidates = await source.GetCandidatesAsync(
                "rome",
                CancellationToken.None);

            Assert.Equal(2, candidates.Count);

            Assert.All(candidates, candidate =>
                Assert.Equal("rome", candidate.DestinationId));
        }

        [Fact]
        public async Task GetCandidatesAsync_ReturnsEmptyList_ForUnsupportedDestination()
        {
            var source = new FixtureCandidateSource();

            var candidates = await source.GetCandidatesAsync(
                "unsupported",
                CancellationToken.None);

            Assert.Empty(candidates);
        }

        [Fact]
        public async Task GetCandidatesAsync_Throws_WhenCancellationRequested()
        {
            var source = new FixtureCandidateSource();

            using var cancellationTokenSource = new CancellationTokenSource();
            cancellationTokenSource.Cancel();

            await Assert.ThrowsAsync<OperationCanceledException>(() =>
                source.GetCandidatesAsync(
                    "istanbul",
                    cancellationTokenSource.Token));
        }
    }
}