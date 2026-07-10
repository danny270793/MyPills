//
//  AppStore.swift
//  MyPills
//
//  Single source of truth for folders and pills, backed by Supabase.
//  Views read its published state and call its methods instead of
//  talking to the services directly.
//

import Foundation
import Observation

@Observable
final class AppStore {
    private(set) var folderSummaries: [FolderSummary] = []
    private(set) var pillsByFolder: [UUID: [Pill]] = [:]
    var errorMessage: String?

    private let folders = FoldersService.shared
    private let pills = PillsService.shared

    func pills(for folderId: UUID) -> [Pill] {
        pillsByFolder[folderId] ?? []
    }

    func loadFolders() async {
        do {
            folderSummaries = try await folders.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadPills(folderId: UUID) async {
        do {
            pillsByFolder[folderId] = try await pills.fetchAll(folderId: folderId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createFolder(name: String) async {
        do {
            _ = try await folders.create(name: name)
            await loadFolders()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func renameFolder(id: UUID, name: String) async {
        do {
            _ = try await folders.rename(id: id, name: name)
            await loadFolders()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteFolder(id: UUID) async {
        do {
            try await folders.delete(id: id)
            pillsByFolder[id] = nil
            await loadFolders()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createPill(_ draft: PillDraft, folderId: UUID) async {
        do {
            _ = try await pills.create(draft, folderId: folderId)
            await loadPills(folderId: folderId)
            await loadFolders()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updatePill(id: UUID, draft: PillDraft, folderId: UUID) async {
        do {
            _ = try await pills.update(id: id, draft: draft, folderId: folderId)
            await loadPills(folderId: folderId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deletePill(id: UUID, folderId: UUID) async {
        do {
            try await pills.delete(id: id)
            await loadPills(folderId: folderId)
            await loadFolders()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
