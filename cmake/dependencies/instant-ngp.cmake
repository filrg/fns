cmake_minimum_required(VERSION 3.14)

include(FetchContent)                                                   
                                                                        
find_package(Git REQUIRED) 

FetchContent_Declare(                                                   
    ingp                                                                
    GIT_REPOSITORY https://github.com/NVlabs/instant-ngp.git            
    GIT_TAG v2.0                                                        
    GIT_SUBMODULES_RECURSE TRUE                                         
)                                                                       
                                                                        
FetchContent_MakeAvailable(ingp)                                        

