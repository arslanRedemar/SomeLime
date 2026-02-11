//
//  DIContainer.swift
//  Somlimee
//
//  Created by Chanhee on 2023/12/22.
//

import Foundation
import Swinject

final class DIContainer {

    static func setupContainer(_ container: Container) {

        // MARK: - Data Sources

        container.register(RemoteDataSource.self) { _ in
            FirebaseDataSource()
        }.inObjectScope(.container)

        container.register(LocalDataSource.self) { _ in
            SQLiteDataSource()
        }.inObjectScope(.container)

        container.register(DataSource.self) { r in
            FirebaseSQLiteDataSource(
                remote: r.resolve(RemoteDataSource.self)!,
                local: r.resolve(LocalDataSource.self)!
            )
        }

        // MARK: - Auth

        container.register(AuthRepository.self) { _ in
            FirebaseAuthRepository()
        }.inObjectScope(.container)

        // MARK: - Repositories

        container.register(AppStateRepository.self) { r in
            AppStateRepositoryImpl(dataSource: r.resolve(DataSource.self)!)
        }

        container.register(UserRepository.self) { r in
            UserRepositoryImpl(dataSource: r.resolve(DataSource.self)!)
        }

        container.register(RealTimeRepository.self) { r in
            RealTimeRepositoryImpl(dataSource: r.resolve(DataSource.self)!)
        }

        container.register(CategoryRepository.self) { r in
            CategoryRepositoryImpl(dataSource: r.resolve(DataSource.self)!)
        }

        container.register(BoardRepository.self) { r in
            BoardRepositoryImpl(dataSource: r.resolve(DataSource.self)!)
        }

        container.register(BoardListRepository.self) { r in
            BoardListRepositoryImpl(dataSource: r.resolve(DataSource.self)!)
        }

        container.register(PostRepository.self) { r in
            PostRepositoryImpl(dataSource: r.resolve(DataSource.self)!)
        }

        container.register(PersonalityTestRepository.self) { r in
            PersonalityTestRepositoryImpl(dataSource: r.resolve(DataSource.self)!)
        }

        container.register(QuestionsRepository.self) { r in
            QuestionsRepositoryImpl(dataSource: r.resolve(DataSource.self)!)
        }

        // MARK: - Use Cases

        container.register(UCGetLimeRoomMeta.self) { r in
            UCGetLimeRoomMetaImpl(boardRepository: r.resolve(BoardRepository.self)!)
        }

        container.register(UCGetLimeRoomPostList.self) { r in
            UCGetLimeRoomPostListImpl(boardRepository: r.resolve(BoardRepository.self)!)
        }

        container.register(UCGetMyLimeRoomMeta.self) { r in
            UCGetMyLimeRoomMetaImpl(
                userRepository: r.resolve(UserRepository.self)!,
                boardRepository: r.resolve(BoardRepository.self)!
            )
        }

        container.register(UCGetMyLimeRoomPostList.self) { r in
            UCGetMyLimeRoomPostListImpl(
                boardRepository: r.resolve(BoardRepository.self)!,
                userRepository: r.resolve(UserRepository.self)!
            )
        }

        container.register(UCGetPost.self) { r in
            UCGetPostImpl(postRepository: r.resolve(PostRepository.self)!)
        }

        container.register(UCWritePost.self) { r in
            UCWritePostImpl(postRepository: r.resolve(PostRepository.self)!)
        }

        container.register(UCGetComments.self) { r in
            UCGetCommentsImpl(postRepository: r.resolve(PostRepository.self)!)
        }

        container.register(UCWriteComment.self) { r in
            UCWriteCommentImpl(postRepository: r.resolve(PostRepository.self)!)
        }

        // MARK: - ViewModels

        container.register(HomeViewModel.self) { r in
            HomeViewModelImpl(
                realTimeRepo: r.resolve(RealTimeRepository.self)!,
                boardRepo: r.resolve(BoardRepository.self)!,
                userRepo: r.resolve(UserRepository.self)!,
                authRepo: r.resolve(AuthRepository.self)!
            )
        }

        container.register(HomeLimesTodayViewModel.self) { r in
            HomeLimesTodayViewModelImpl(
                boardRepo: r.resolve(BoardRepository.self)!
            )
        }

        container.register(SideMenuViewModel.self) { r in
            SideMenuViewModelImpl(
                categoryRepo: r.resolve(CategoryRepository.self)!
            )
        }

        container.register(ProfileViewModel.self) { r in
            ProfileViewModelImpl(
                userRepo: r.resolve(UserRepository.self)!,
                personalityTestRepo: r.resolve(PersonalityTestRepository.self)!,
                authRepo: r.resolve(AuthRepository.self)!
            )
        }

        container.register(LimeRoomViewModel.self) { r in
            LimeRoomViewModelImpl(
                getLimeRoomMeta: r.resolve(UCGetLimeRoomMeta.self)!,
                getLimeRoomPostList: r.resolve(UCGetLimeRoomPostList.self)!
            )
        }

        container.register(BoardPostViewModel.self) { r in
            BoardPostViewModelImpl(
                getPost: r.resolve(UCGetPost.self)!,
                getComments: r.resolve(UCGetComments.self)!,
                writeComment: r.resolve(UCWriteComment.self)!
            )
        }

        container.register(BoardPostWriteViewModel.self) { r in
            BoardPostWriteViewModelImpl(
                writePost: r.resolve(UCWritePost.self)!,
                authRepo: r.resolve(AuthRepository.self)!
            )
        }

        container.register(UserCurrentCommentsViewModel.self) { r in
            UserCurrentCommentsViewModelImpl(
                userRepo: r.resolve(UserRepository.self)!
            )
        }

        container.register(UserCurrentPostsViewModel.self) { r in
            UserCurrentPostsViewModelImpl(
                userRepo: r.resolve(UserRepository.self)!
            )
        }

        container.register(ForgotPasswordViewModel.self) { r in
            ForgotPasswordViewModelImpl(
                authRepo: r.resolve(AuthRepository.self)!
            )
        }

        container.register(VerifyEmailViewModel.self) { r in
            VerifyEmailViewModelImpl(
                authRepo: r.resolve(AuthRepository.self)!
            )
        }

        container.register(ProfileSettingsViewModel.self) { r in
            ProfileSettingsViewModelImpl(
                userRepo: r.resolve(UserRepository.self)!,
                authRepo: r.resolve(AuthRepository.self)!
            )
        }

        container.register(ChangePasswordViewModel.self) { r in
            ChangePasswordViewModelImpl(
                authRepo: r.resolve(AuthRepository.self)!
            )
        }
    }
}
