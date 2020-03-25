import D2Utils
import Foundation
import Logging

fileprivate let log = Logger(label: "RemoteGitLab")
fileprivate let apiPath = "/api/v4"

public struct RemoteGitLab {
    private let scheme: String
    private let host: String

    public init(scheme: String = "https", host: String) {
        self.scheme = scheme
        self.host = host
    }
    
    private func request(for endpointPath: String) throws -> HTTPRequest {
        let headers = storedNetApiKeys?.gitlab.map { ["Private-Token": $0] } ?? [:]
        return try HTTPRequest(scheme: scheme, host: host, path: apiPath + endpointPath, headers: headers)
    }
    
    private func fetchString(from endpointPath: String, then: @escaping (Result<String, Error>) -> Void) {
        do {
            log.info("Querying \(endpointPath) from GitLab \(host)")
            return try request(for: endpointPath).fetchUTF8Async(then: then)
        } catch {
            then(.failure(error))
        }
    }
    
    private func fetchJSON<T>(as type: T.Type, from endpointPath: String, then: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        do {
            log.info("Querying \(endpointPath) as JSON from GitLab \(host)")
            return try request(for: endpointPath).fetchJSONAsync(as: type, then: then)
        } catch {
            then(.failure(error))
        }
    }
    
    public func fetchPipelines(projectId: Int, then: @escaping (Result<[GitLabPipeline], Error>) -> Void) {
        fetchJSON(as: [GitLabPipeline].self, from: "/projects/\(projectId)/pipelines", then: then)
    }
    
    public func fetchPipeline(projectId: Int, pipelineId: Int, then: @escaping (Result<GitLabPipeline, Error>) -> Void) {
        fetchJSON(as: GitLabPipeline.self, from: "/projects/\(projectId)/pipelines/\(pipelineId)", then: then)
    }
    
    public func fetchPipelineJobs(projectId: Int, pipelineId: Int, then: @escaping (Result<[GitLabJob], Error>) -> Void) {
        fetchJSON(as: [GitLabJob].self, from: "/projects/\(projectId)/pipelines/\(pipelineId)/jobs", then: then)
    }
    
    public func fetchJobs(projectId: Int, then: @escaping (Result<[GitLabJob], Error>) -> Void) {
        fetchJSON(as: [GitLabJob].self, from: "/projects/\(projectId)/jobs", then: then)
    }
    
    public func fetchJobLog(projectId: Int, jobId: Int, then: @escaping (Result<String, Error>) -> Void) {
        fetchString(from: "/projects/\(projectId)/jobs/\(jobId)/trace", then: then)
    }
}